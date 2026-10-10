module Reports
  class SalesController < ApplicationController
    def show
      @from = date_param(:from) || Date.current.beginning_of_week
      @to = date_param(:to) || Date.current

      units = Current.enterprise.invoice_products
        .products_sold_between(@from, @to)
        .group("invoices.employee_id", :product_id)
        .sum(:quantity)

      employees = Current.enterprise.employees.where(id: units.keys.map(&:first)).index_by(&:id)
      products = Current.enterprise.products.where(id: units.keys.map(&:last)).index_by(&:id)

      # One row per employee + product, most units first
      @rows = units.map do |(employee_id, product_id), quantity|
        { employee: employees[employee_id], product: products[product_id], units: quantity }
      end.sort_by { |row| -row[:units] }
    end
  end
end
