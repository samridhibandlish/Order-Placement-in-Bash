#!/bin/bash

# User registration
register() {
    
    echo "User Registration"
    echo "-----------------"

    echo "Enter your name: "
    read name

    echo "Enter your email: "
    read email

    # Save user information to a text file
    echo "$name:$email" >> users.txt

    echo "Registration successful!"
    echo "Press any key to continue..."
    read
    log_in
}

# User login
log_in() {
    clear
    echo "User Login"
    echo "----------"

    echo "Enter your email: "
    read email

    # Check if the user exists in the database
    if grep -q "$email" users.txt; 
    then
        echo "Login successful!"
        echo "Press any key to continue..."
        read
        show_items
    else
        echo "User not found. Please register first."
        echo "Press any key to continue..."
        read
        register
    fi
}

# Show available items and corresponding prices
show_items() {
    clear
    echo "Items Available"
    echo "---------------"

    # Read items and prices using awk from a text file
    awk -F ":" '{printf "%s - %s\n", $1, $2}' items.txt

    echo "Press 1 to add an item to the cart"
    echo "Press 2 to remove an item from the cart"
    echo "Press 3 to buy items"
    echo "Press 4 to exit"
    echo "Enter your choice: "
    read choice

    case $choice in
        1)
            add_to_cart
            ;;
        2)
            remove_from_cart
            ;;
        3)
            buy_items
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            echo "Press any key to continue..."
            read
            show_items
            ;;
    esac
}

# Add an item to the cart
add_to_cart() {
    clear
    echo "Add Item to Cart"
    echo "----------------"

    echo "Enter the name of the item to add: "
    read item_name

    # Check if the item exists in the database using grep and regular expression
    if grep -q "^$item_name:" items.txt; then
        # Save item to the cart file
        echo "$item_name" >> cart.txt
        echo "Item added to the cart!"
    else
        echo "Item not found."
    fi

    echo "Press any key to continue..."
    read
    show_items
}

# Remove an item from the cart
remove_from_cart() {
    clear
    echo "Remove Item from Cart"
    echo "---------------------"

    echo "Enter the name of the item to remove: "
    read item_name

    # Check if the item exists in the cart using grep and regular expression
    if grep -q "^$item_name$" cart.txt; then
        # Remove item from the cart file using sed
        sed -i "/^$item_name$/d" cart.txt
        echo "Item removed from the cart!"
    else
        echo "Item not found in the cart."
    fi

    echo "Press any key to continue..."
    read
    show_items
}

# Buy items and send order confirmation email
buy_items() {
    clear
    echo "Buy Items"
    echo "---------"

    cat cart.txt
    # Read items from the cart file
    items=$(cat cart.txt)

    # Calculate the total price
    total_price=0

    while read -r item; do
        # Extract the price of the item from the items.txt file using awk and regex
        price=$(grep "^$item:" items.txt | awk -F ":" '{print $2}')
        
        # Add the price to the total
        total_price=$(echo "$total_price + $price" | bc)
    done <<< "$items"

    echo " "
    echo "Total price: $total_price"
    echo " "

    # Ask for payment information
    echo "Enter your payment information: "
    read payment_info

    # Send order confirmation email (you can customize the email content)
    email_subject="Order Confirmation"
    email_body="Thank you for your purchase!\n\nItems: $items\nTotal price: $total_price\nPayment information: $payment_info"

    echo -e "$email_body" | mail -s "$email_subject" $email

    echo "Order confirmed. An email confirmation has been sent to $email"
    
    # Clear the cart file
    > cart.txt

    echo "Press any key to continue..."
    read
    show_items
}

echo "Do you have an account? (y/n)"
read answer

if [ "$answer" = "n" ];
then
    register
else
    log_in
fi
