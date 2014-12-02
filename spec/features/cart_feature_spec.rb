require "rails_helper"

feature "the cart works" do
  before(:each) do
    item = MenuItem.create! title: "Item in both", description: "a", price: 1
    Category.create!(title: "Testing") do |cat|
      cat.menu_items.build title: "Tuna Poke", description: "a", price: 1
      cat.menu_items.build title: "Miso Soup", description: "a", price: 1
      cat.menu_items << item
    end
    Category.create!(title: "Testing Two") do |cat|
      cat.menu_items.build title: "Test Item", description: "a", price: 1
      cat.menu_items << item
    end
  end

  it "can add multiple items to the cart from one category" do
    visit "/cart"
    expect(page).to_not have_content "Tuna Poke"

    visit "/menu"
    within(".tuna-poke") do
      click_link_or_button "Add To Cart"
    end

    visit "/cart"
    expect(page).to have_content "Tuna Poke"
    expect(page).to_not have_content "Miso"

    visit "/menu"
    within(".miso-soup") do
      click_link_or_button "Add To Cart"
    end

    visit "/cart"
    expect(page).to have_content "Miso"
  end

  it "can add more than 1 of a single item" do
    visit "/cart"
    expect(page).to_not have_content "Miso"

    visit "/menu"
    3.times do
      within(".miso-soup") do
        click_link_or_button "Add To Cart"
      end
    end

    visit "/cart"
    within(".miso-soup") do
      expect(page).to_not have_content "1"
      expect(page).to have_content "3"
    end
  end

  it "can add items from multiple categories" do
    visit "/cart"
    expect(page).to_not have_content "Tuna Poke"

    visit "/menu"
    within(".tuna-poke") do
      click_link_or_button "Add To Cart"
    end

    visit "/cart"
    expect(page).to have_content "Tuna Poke"
    expect(page).to_not have_content "Test Item"

    visit "/menu"
    within(".test-item") do
      click_link_or_button "Add To Cart"
    end

    visit "/cart"
    expect(page).to have_content "Test Item"
  end

  it "can remove items from the cart" do
    visit "/menu"
    within(".tuna-poke") do
      click_link_or_button "Add To Cart"
    end

    visit "/cart"
    expect(page).to have_content "Tuna Poke"

    within(".tuna-poke") do
      click_link_or_button "Remove From Cart"
    end
    expect(page).to_not have_content "Tuna Poke"
  end

  it "can completely clear the cart" do
    visit "/menu"
    within(".tuna-poke") do
      click_link_or_button "Add To Cart"
    end
    within(".test-item") do
      click_link_or_button "Add To Cart"
    end

    visit "/cart"
    expect(page).to have_content "Tuna Poke"
    expect(page).to have_content "Test Item"
    click_link_or_button "Clear Cart"
    expect(page).to_not have_content "Tuna Poke"
    expect(page).to_not have_content "Test Item"
  end

  it "can add large quantities" do
    visit "/menu"
    click_link_or_button "Tuna Poke".upcase
    fill_in "menu_item[amount]", with: 666
    click_link_or_button "Add To Cart"

    visit "/cart"
    within(".tuna-poke") do
      expect(page).to_not have_content "1"
      expect(page).to have_content "666"
    end
  end

  it "adds to same item if clicked from different categories" do
    visit "/cart"
    expect(page).to_not have_content "Item in both"
    visit "/menu"

    within(".item-in-both:nth-of-type(1)") do
      click_link_or_button "Add To Cart"
    end
    within(".item-in-both:nth-of-type(2)") do
      click_link_or_button "Add To Cart"
    end

    visit "/cart"
    expect(page).to have_content "Item in both"
    within(".item-in-both") do
      expect(page).to_not have_content "1"
      expect(page).to have_content "2"
    end

  end
end
