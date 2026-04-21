package com.configurator.model;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "wheel_designs")
public class WheelDesign {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private String name;

    @Column(name = "model_object", nullable = false)
    private String modelObject;

    @Column(nullable = false)
    private BigDecimal price;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getModelObject() { return modelObject; }
    public void setModelObject(String modelObject) { this.modelObject = modelObject; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
}
