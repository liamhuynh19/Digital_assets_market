require "csv"
require "set"

class ImportProductJob < ApplicationJob
  queue_as :default

  def perform(user_id, file_data)
    sleep 5
    actor = User.find_by(id: user_id)
    return unless actor

    is_seller      = actor.role == "seller"
    raw_rows       = []
    needed_emails  = Set.new
    needed_cat_ids = Set.new

    csv_io = StringIO.new(file_data)
    CSV.new(csv_io, headers: true).each_with_index do |row, idx|
      line_no = idx + 2
      data = (row.to_hash || {}).transform_keys { |k| k.to_s.strip }
      raw_rows << { line: line_no, data: data }

      unless is_seller
        email = data["user_email"].to_s.strip
        needed_emails << email unless email.empty?
      end
      cat_id = data["category_id"].to_s.strip
      needed_cat_ids << cat_id.to_i if cat_id.match?(/\A\d+\z/)
    end

    users_by_email = {}
    if !is_seller && needed_emails.any?
      users_by_email = User.where(email: needed_emails.to_a).index_by(&:email)
    end
    existing_category_ids = Category.where(id: needed_cat_ids.to_a).pluck(:id).to_set

    errors      = []
    insert_rows = []
    now = Time.current

    raw_rows.each do |row|
      line = row[:line]; d = row[:data]

      name         = d["name"].to_s.strip
      description  = d["description"].to_s.strip
      price_str    = d["price"].to_s.strip
      category_raw = d["category_id"].to_s.strip
      email        = d["user_email"].to_s.strip

      user_id = is_seller ? actor.id : users_by_email[email]&.id

      row_errors = []
      row_errors << "Name is blank" if name.blank?

      price_val =
        begin
          price_str.blank? ? nil : BigDecimal(price_str)
        rescue ArgumentError
          nil
        end
      row_errors << "Invalid price" if price_val.nil? || price_val <= 0

      unless category_raw.match?(/\A\d+\z/) && existing_category_ids.include?(category_raw.to_i)
        row_errors << "Category not found"
      end

      if !is_seller && user_id.nil?
        row_errors << "User email '#{email}' not found"
      end

      if row_errors.any?
        errors << { line: line, errors: row_errors }
        next
      end

      insert_rows << {
        name:        name,
        description: description.presence,
        price:       price_val,
        category_id: category_raw.to_i,
        user_id:     user_id,
        status:      "draft",
        created_at:  now,
        updated_at:  now
      }
    end

    result =
      if errors.any?
        { aborted: true, imported: 0, errors: errors }
      elsif insert_rows.empty?
        { aborted: true, imported: 0, errors: [ { line: nil, errors: [ "No valid rows" ] } ] }
      else
        begin
          Product.transaction { Product.insert_all!(insert_rows) }
          { aborted: false, imported: insert_rows.size, errors: [] }
        rescue ActiveRecord::RecordNotUnique => e
          { aborted: true, imported: 0, errors: [ { line: nil, errors: [ "Duplicate: #{e.message}" ] } ] }
        rescue ActiveRecord::InvalidForeignKey => e
          { aborted: true, imported: 0, errors: [ { line: nil, errors: [ "Foreign key: #{e.message}" ] } ] }
        rescue => e
          { aborted: true, imported: 0, errors: [ { line: nil, errors: [ "#{e.class} #{e.message}" ] } ] }
        end
      end

    Rails.cache.write(
      cache_key(actor),
      {
        at:        Time.current,
        aborted:   result[:aborted],
        imported:  result[:imported],
        errors:    result[:errors]
      },
      expires_in: 2.hours
    )
  end

  private

  def cache_key(user)
    "bulk_import_products:result:user:#{user.id}"
  end
end
