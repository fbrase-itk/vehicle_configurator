-- Car models table (the base vehicle)
CREATE TABLE IF NOT EXISTS car_models (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model_file VARCHAR(200) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    description TEXT
);

-- Engine options linked to specific car models
CREATE TABLE IF NOT EXISTS engine_options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    car_model_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    horsepower INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (car_model_id) REFERENCES car_models(id)
);

CREATE TABLE IF NOT EXISTS paint_options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    color_code VARCHAR(7) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS wheel_designs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    model_object VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS wheel_colors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    color_code VARCHAR(7) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS caliper_colors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    color_code VARCHAR(7) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS special_equipment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS configurations (
    id VARCHAR(36) PRIMARY KEY,
    car_model_id INT,
    engine_id INT,
    paint_id INT,
    wheel_design_id INT,
    wheel_color_id INT,
    caliper_color_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (car_model_id) REFERENCES car_models(id),
    FOREIGN KEY (engine_id) REFERENCES engine_options(id),
    FOREIGN KEY (paint_id) REFERENCES paint_options(id),
    FOREIGN KEY (wheel_design_id) REFERENCES wheel_designs(id),
    FOREIGN KEY (wheel_color_id) REFERENCES wheel_colors(id),
    FOREIGN KEY (caliper_color_id) REFERENCES caliper_colors(id)
);

CREATE TABLE IF NOT EXISTS configuration_equipment (
    configuration_id VARCHAR(36),
    equipment_id INT,
    PRIMARY KEY (configuration_id, equipment_id),
    FOREIGN KEY (configuration_id) REFERENCES configurations(id),
    FOREIGN KEY (equipment_id) REFERENCES special_equipment(id)
);

CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    configuration_id VARCHAR(36) NOT NULL,
    customer_name VARCHAR(200),
    customer_email VARCHAR(200),
    total_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (configuration_id) REFERENCES configurations(id)
);

-- Seed data

-- All prices are stored in EUR (converted from USD at 1 USD = 0.92 EUR).

-- Car Models
INSERT INTO car_models (name, brand, model_file, base_price, description) VALUES
('Aventador LP700-4', 'Lamborghini', '/models/aventador.glb', 362199.40, 'The Lamborghini Aventador is a mid-engine sports car. The Aventador''s V12 engine produces 700 HP.');

-- Engine options for Aventador (car_model_id = 1)
INSERT INTO engine_options (car_model_id, name, horsepower, price) VALUES
(1, 'V12 6.5L LP700', 700, 0.00),
(1, 'V12 6.5L LP720 (50th Anniversary)', 720, 23000.00),
(1, 'V12 6.5L LP750 SV', 750, 41400.00),
(1, 'V12 6.5L LP770 SVJ', 770, 78200.00);

-- Paint options (Lamborghini colors)
INSERT INTO paint_options (name, color_code, price) VALUES
('Bianco Monocerus', '#F2F3F5', 0.00),
('Nero Aldebaran', '#1a1a1a', 2300.00),
('Rosso Mars', '#BF0012', 3220.00),
('Arancio Atlas', '#F77F21', 3220.00),
('Arancio Argos', '#FC4705', 3220.00),
('Blu Cepheus', '#4393E6', 3680.00),
('Verde Mantis', '#7FBA00', 4140.00),
('Giallo Orion', '#FFD700', 4140.00);

-- Wheel designs (mapped to 3D model objects)
INSERT INTO wheel_designs (name, model_object, price) VALUES
('Dione', 'Obj_Rim_T0A', 0.00),
('Mimas', 'Obj_Rim_T0B', 4600.00);

-- Wheel colors
INSERT INTO wheel_colors (name, color_code, price) VALUES
('Gloss Black', '#000000', 0.00),
('Titanium Grey', '#4C5457', 1380.00),
('Silver Metallic', '#dddddd', 2300.00);

-- Brake caliper colors
INSERT INTO caliper_colors (name, color_code, price) VALUES
('Red', '#990000', 0.00),
('Yellow', '#E9A435', 460.00),
('Black', '#000000', 460.00),
('White', '#F1F7F7', 690.00);

-- Special equipment
INSERT INTO special_equipment (name, description, price) VALUES
('Carbon Fiber Exterior Package', 'Front splitter, side skirts, rear diffuser in carbon fiber', 13800.00),
('Carbon Fiber Interior Package', 'Dashboard, door panels, center console in carbon fiber', 11040.00),
('Lifting System', 'Front axle lifting system for steep driveways', 7820.00),
('Sensonum Sound System', 'Premium Sensonum surround sound system', 5060.00),
('Transparent Engine Bonnet', 'Glass engine cover to showcase V12', 6900.00);
