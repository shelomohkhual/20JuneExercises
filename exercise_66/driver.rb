require 'byebug'
require 'open-uri'
require 'nokogiri'
require 'colorize'


# menu_items = cafe.css("li.menu-list-item")
class Input
    attr_reader :opend_html
    def initialize(file)
         @opend_html = Nokogiri::HTML(open('./html-samples/cafeteria.html'))
    end
end

class Menu 
    attr_reader :menu_lists,:opend_html
    def initialize(opend_html)
    # @menu_lists={|name,details|name[details]=[]}
    @menu_lists=[]
    @opend_html=opend_html
    end

    def add_menu_list

        html_menu_list=@opend_html.css('li.menu-list-item')
        html_menu_list.each_with_index do |each,index|
            menu_item_count="menu_item_#{index+1}"
            name=@opend_html.css("h1.menu-list-item-entree-name")[index].text
            sides=@opend_html.css("span.menu-list-item-sides")[index].text
            price=@opend_html.css("span.menu-list-item_price")[index].text
            @menu_lists<<menu_item_count=Menu_Item.new(name,sides,price)
            # count += 1
        end

        # loop do
        #     @opend_html.css('li.menu-list-item')[count]
        #     break if nil
        #     menu_item_count="menu_item_#{count+1}"
        #     byebug
        #     name=@opend_html.css("h1.menu-list-item-entree-name")[count].text
        #     sides=@opend_html.css("span.menu-list-item-sides")[count].text
        #     price=@opend_html.css("span.menu-list-item_price")[count].text
        #     @menu_lists<<menu_item_count=Menu_Item.new(name,sides,price)
        #     count += 1
        # end
    end

    def include_in_menu?(search)
        @menu_lists.each do |menu_item|
            if menu_item.item_include? search
                return true
                break 
            else nil
            end
        end
        false
    end

    def menu_search(search)
        if self.include_in_menu?(search)
            @menu_lists.each do |menu_item|
                if menu_item.item_include?(search)
                    puts
                    puts "Name  : ".green + menu_item.name.upcase
                    puts "Sides : ".green + menu_item.sides
                    puts "Price : ".green + menu_item.price
                    puts
                else nil
                end
            end 
        else puts "Doesn't Serve #{search}".red
        end
    end
end

class Menu_Item
    attr_accessor :name, :sides, :price
    def initialize(name,sides,price)
        @name=name
        @sides=sides
        @price=price
    end

    def item_include?(search)
        downcase_sides=@sides.downcase
        downcase_name=@name.downcase
        (downcase_sides || downcase_name).include? search.downcase
    end
end

cafeteria_html = Input.new('./html-samples/cafeteria.html')
cafeteria_menu = Menu.new(cafeteria_html.opend_html)
cafeteria_menu.add_menu_list

puts "Find Name of Dishes (or) Dishes of Sides".yellow
search=gets.chomp
cafeteria_menu.menu_search(search)


