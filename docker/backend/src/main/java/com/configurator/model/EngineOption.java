package com.configurator.model;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.math.BigDecimal;

@Entity
@Table(name = "engine_options")
public class EngineOption {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "car_model_id", nullable = false)
    @JsonIgnore
    private CarModel carModel;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private Integer horsepower;

    @Column(nullable = false)
    private BigDecimal price;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public CarModel getCarModel() { return carModel; }
    public void setCarModel(CarModel carModel) { this.carModel = carModel; }
    public Integer getCarModelId() { return carModel != null ? carModel.getId() : null; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getHorsepower() { return horsepower; }
    public void setHorsepower(Integer horsepower) { this.horsepower = horsepower; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
}
