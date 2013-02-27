module Rex11
  class Item
    attr_accessor :style, :upc, :size, :price, :color, :description

    def initialize(style, upc, size, price, color, description = nil)
      @style, @upc, @size, @price, @color, @description = style, upc, size, price, color, description
    end
  end
end