-- A database for a wool shop

-- Create the database
CREATE DATABASE wonderful_wool;

-- Use this database
USE wonderful_wool;

-- Create the yarn table
CREATE TABLE yarn (
item_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
brand_name VARCHAR(50) NOT NULL,
item_name VARCHAR(50) NOT NULL,
price FLOAT(2) NOT NULL,
fibre VARCHAR(50) NOT NULL,
colour VARCHAR(50) NOT NULL,
yarn_weight VARCHAR(50) NOT NULL,
ball_weight_g INT NOT NULL,
stock_quantity INT
);

-- Create the loyalty card holders table
CREATE TABLE loyalty_card_holders (
membership_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email_address VARCHAR(50) NOT NULL,
points INT
);

-- Create the purchases table
CREATE TABLE purchases (
purchase_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
quantity INT NOT NULL,
purchase_date DATE NOT NULL,
item_id INT,
FOREIGN KEY (item_id) REFERENCES yarn(item_id),
membership_id INT,
FOREIGN KEY (membership_id) REFERENCES loyalty_card_holders(membership_id)
);

-- Insert data into the yarn table
INSERT INTO yarn 
(brand_name, item_name, price, fibre, colour, yarn_weight, ball_weight_g, stock_quantity)
VALUES
("Best Yarn", "Best DK", 2.49, "acrylic", "red", "DK", 100, 20),
("Top Wool", "Pure Chunky", 5.89, "wool", "orange", "chunky", 100, 22),
("Owlpaca Magic", "Warm Aran", 4.99, "alpaca", "yellow", "aran", 100, 43),
("Top Wool", "Baby Soft", 2.99, "merino wool", "green", "DK", 50, 38),
("Best Yarn", "Value Super Chunky", 3.49, "acrylic", "blue", "super chunky", 200, 14),
("Natures Fibres", "Cotton DK", 3.59, "cotton", "purple", "DK", 100, 36),
("Owlpaca Magic", "Owlpaca DK", 3.89, "alpaca", "pink", "DK", 100, 24),
("Top Wool", "Extreme Chunky", 8.49, "wool", "red", "super chunky", 200, 17),
("Natures Fibres", "Wool Soft", 4.99, "wool", "orange", "DK", 100, 22),
("Best Yarn", "Best Aran", 3.65, "acrylic", "yellow", "aran", 100, 12);

-- Insert data into the loyalty card holders table
INSERT INTO loyalty_card_holders 
(first_name, last_name, email_address, points)
VALUES
("Sanaa", "Snow", "sanaa.snow@fakeemailaddress.fake", 12),
("Cory", "Miller", "c.miller@fakeurl.fake", 8),
("Tomas", "Whitehead", "tomas.whitehead@fakeemail4u.fake", 0),
("Pearl", "Ali", "p.ali@fakeurl.fake", 0),
("Mohammed", "Larson", "mohammed_larson@fakeemail4u.fake", 2),
("Theodore", "Barron", "t.barron@fakeemailaddress.fake", 12),
("Keeley", "Richmond", "keeley.richmond@fakeurl.fake", 0),
("Zachery", "Lyons", "z.lyons@fakeemail4u.fake", 5),
("Pedro", "Gillespie", "pedro_gillespie@fakeemailaddress.fake", 0),
("Mikey", "Pineda", "m.pineda@fakeurl.fake", 2);

-- Insert data into the purchases table
INSERT INTO purchases
(quantity, purchase_date, item_id, membership_id)
VALUES
(12, "2022-01-28", 1, 1),
(2, "2023-02-03", 10, 5),
(5, "2021-03-20", 2, null),
(2, "2022-01-12", 9, 10),
(6, "2023-03-15", 3, 2),
(2, "2022-12-06", 8, 2),
(4, "2021-11-19", 1, null),
(8, "2023-02-18", 1, 6),
(4, "2021-10-15", 6, 6),
(5, "2023-02-20", 1, 8);

-- Mohammed Larson wants to know what DK weight yarn is available at what price
SELECT * FROM yarn
WHERE yarn_weight = "DK"
ORDER BY price;

-- Mohammed Larson decides to buy 10 of each DK yarn apart from the merino wool
-- Query to find out Mohammed Larson's membership id --
SELECT membership_id FROM loyalty_card_holders
WHERE first_name = "Mohammed" AND last_name = "Larson";

-- Procedure to handle purchases by a loyalty card holder
DELIMITER //
CREATE PROCEDURE purchase(purchase_item_id INT, purchase_quantity INT, purchase_membership_id INT)
BEGIN

UPDATE yarn
SET stock_quantity = stock_quantity - purchase_quantity
WHERE item_id = purchase_item_id;

INSERT INTO purchases (quantity, purchase_date, item_id, membership_id)
VALUES (
purchase_quantity,  
CURRENT_DATE(),
purchase_item_id,
purchase_membership_id
);

UPDATE loyalty_card_holders
SET points = points + purchase_quantity
WHERE membership_id = purchase_membership_id;

END //
DELIMITER ;

-- Procedure called for each item Mohammed Larson has decided to buy
CALL purchase(1, 10, 5);
CALL purchase(6, 10, 5);
CALL purchase(7, 10, 5);
CALL purchase(9, 10, 5);

-- The manager wants to know what the average price of yarn is
-- Query to display the average price of yarn
SELECT ROUND(AVG(price), 2) FROM yarn;

-- A customer wants 12 balls of aran weight yarn
-- Query to display all aran weight yarns with a quantity of 12 or more
SELECT * FROM yarn
WHERE yarn_weight = "aran" AND stock_quantity >= 12
ORDER BY price;

-- Tomas Whitehead wants to cancel his loyalty card --
-- check that there is only one Tomas Whitehead and what his membership_id is
SELECT * FROM loyalty_card_holders
WHERE first_name = "Tomas" AND last_name = "Whitehead";

-- Delete Tomas Whitehead's entry using his membership id
DELETE FROM loyalty_card_holders
WHERE membership_id = 3;

-- View all purchases most recent to oldest
SELECT * FROM purchases
ORDER BY purchase_date DESC;

-- View all loyalty card holders' purchases
SELECT 
loyalty_card_holders.first_name, loyalty_card_holders.last_name, 
purchases.quantity, purchases.purchase_date, 
yarn.brand_name, yarn.item_name, yarn.colour, yarn.yarn_weight
FROM ((loyalty_card_holders
INNER JOIN purchases ON loyalty_card_holders.membership_id = purchases.membership_id)
INNER JOIN yarn ON purchases.item_id = yarn.item_id)
ORDER BY loyalty_card_holders.last_name;

-- View most popular yarn -- 
SELECT 
purchases.item_id, SUM(purchases.quantity) AS total_purchase_quantity, 
yarn.brand_name, yarn.item_name, yarn.colour, yarn.yarn_weight
FROM purchases
LEFT JOIN yarn ON purchases.item_id = yarn.item_id
GROUP BY purchases.item_id
ORDER BY total_purchase_quantity DESC;
