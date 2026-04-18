CREATE TABLE IF NOT EXISTS engine_options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    horsepower INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS paint_options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    color_code VARCHAR(7) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS wheel_options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    size VARCHAR(20) NOT NULL,
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
    engine_id INT,
    paint_id INT,
    wheel_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (engine_id) REFERENCES engine_options(id),
    FOREIGN KEY (paint_id) REFERENCES paint_options(id),
    FOREIGN KEY (wheel_id) REFERENCES wheel_options(id)
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
INSERT INTO engine_options (name, horsepower, price) VALUES
('Base 1.6L', 120, 0.00),
('Sport 2.0L', 180, 3500.00),
('Performance 2.5L Turbo', 280, 8000.00),
('V6 3.0L', 320, 12000.00);

INSERT INTO paint_options (name, color_code, price) VALUES
('Arctic White', '#FFFFFF', 0.00),
('Midnight Black', '#1a1a1a', 500.00),
('Racing Red', '#cc0000', 800.00),
('Ocean Blue', '#0066cc', 800.00),
('Forest Green', '#228b22', 600.00);

INSERT INTO wheel_options (name, size, price) VALUES
('Standard Steel 16"', '16 inch', 0.00),
('Alloy Sport 17"', '17 inch', 1200.00),
('Premium Alloy 18"', '18 inch', 2000.00),
('Performance 19"', '19 inch', 3500.00);

INSERT INTO special_equipment (name, description, price) VALUES
('Air Conditioning', 'Automatic climate control system', 1500.00),
('Premium Sound System', 'Bose 12-speaker surround sound', 2500.00),
('Driver Safety Package', 'Lane assist, blind spot monitoring, collision warning', 3000.00),
('Leather Interior', 'Full leather seats with heating', 4000.00),
('Panoramic Sunroof', 'Full glass panoramic roof with tint', 2000.00);
