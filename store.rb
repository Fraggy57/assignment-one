require 'json'

class Store
  attr_accessor :total_sale
  @@items
  
  def initialize
    @total_sale = 0.0
  end
  
  def import_items(filename)
    file = File.read(filename)
    @@items = JSON.parse(file, :symbolize_names => true)
  end
  
  def search(args)
    found_items = @@items
    args.each do |key,value|
      if key==:available
        found_items = found_items.select{ |item| item[:in_store]>0 }
      else
        found_items = found_items.select{ |item| item[key].to_s.downcase==value.to_s.downcase }
      end
    end
    found_items
  end
  
  def items_sorted_by(attr, ord)
    if ord==:asc
      return @@items.sort{ |a,b| a[attr]<=>b[attr] }
    else
      return @@items.sort{ |a,b| b[attr]<=>a[attr] }
    end
  end
  
  def categories
    return @@items.map{|item| item[:category]}.uniq
  end
  
  def unique_articles_in_category(category)
    products = @@items.select{ |item| item[:category].to_s.downcase==category.to_s.downcase }
    return products.map{|item| item[:name]}.uniq
  end
  
  def show
    puts @@items
  end
end

class Store::Cart
  attr_accessor :store
  attr_accessor :items
  
  def initialize(store)
    @store = store
    @items=[]
  end
  
  def total_cost
    if @items.length==0
      return 0.0
    end
    return @items.map{|item| item[:price]}.inject{ |sum,x| sum+x }.round(2)
  end
  
  def total_items
    return @items.length
  end
  
  def unique_items
    @items.uniq
  end
  
  def add_item(item,n=1)
    if item[:in_store]<=n
      n=item[:in_store]
    end
    n.times{ items.push(item) }
  end
  
  def checkout!
    @items.each do |item|
      item[:in_store]-=1
      @store.total_sale += item[:price]
    end
  end
end

class Hash
  def method_missing(key)
    self[key]
  end
end