module Rex11
  class Address
    attr_accessor :first_name, :last_name, :company_name, :address1, :address2, :city, :state, :zip, :country, :non_us_region, :phone, :email

    def initialize(first_name, last_name, company_name, address1, address2, city, state, zip, country, non_us_region, phone, email)
      @first_name, @last_name, @company_name, @address1, @address2, @city, @state, @zip, @country, @non_us_region, @phone, @email = first_name, last_name, company_name, address1, address2, city, state, zip, country, non_us_region, phone, email
    end
  end
end