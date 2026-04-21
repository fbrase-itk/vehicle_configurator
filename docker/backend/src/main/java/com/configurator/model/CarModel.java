package com.configurator.model;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "car_models")
public class CarModel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String brand;

    @Column(name = "model_file", nullable = false)
    private String modelFile;

    @Column(name = "base_price", nullable = false)
    private BigDecimal basePrice;

    @Column
    private String description;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    public String getModelFile() { return modelFile; }
    public void setModelFile(String modelFile) { this.modelFile = modelFile; }
    public BigDecimal getBasePrice() { return basePrice; }
    public void setBasePrice(BigDecimal basePrice) { this.basePrice = basePrice; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
