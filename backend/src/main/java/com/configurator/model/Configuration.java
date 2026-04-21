package com.configurator.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "configurations")
public class Configuration {
    @Id
    private String id;

    @ManyToOne
    @JoinColumn(name = "car_model_id")
    private CarModel carModel;

    @ManyToOne
    @JoinColumn(name = "engine_id")
    private EngineOption engine;

    @ManyToOne
    @JoinColumn(name = "paint_id")
    private PaintOption paint;

    @ManyToOne
    @JoinColumn(name = "wheel_design_id")
    private WheelDesign wheelDesign;

    @ManyToOne
    @JoinColumn(name = "wheel_color_id")
    private WheelColor wheelColor;

    @ManyToOne
    @JoinColumn(name = "caliper_color_id")
    private CaliperColor caliperColor;

    @ManyToMany
    @JoinTable(
        name = "configuration_equipment",
        joinColumns = @JoinColumn(name = "configuration_id"),
        inverseJoinColumns = @JoinColumn(name = "equipment_id")
    )
    private Set<SpecialEquipment> equipment = new HashSet<>();

    @Column(name = "created_at")
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public CarModel getCarModel() { return carModel; }
    public void setCarModel(CarModel carModel) { this.carModel = carModel; }
    public EngineOption getEngine() { return engine; }
    public void setEngine(EngineOption engine) { this.engine = engine; }
    public PaintOption getPaint() { return paint; }
    public void setPaint(PaintOption paint) { this.paint = paint; }
    public WheelDesign getWheelDesign() { return wheelDesign; }
    public void setWheelDesign(WheelDesign wheelDesign) { this.wheelDesign = wheelDesign; }
    public WheelColor getWheelColor() { return wheelColor; }
    public void setWheelColor(WheelColor wheelColor) { this.wheelColor = wheelColor; }
    public CaliperColor getCaliperColor() { return caliperColor; }
    public void setCaliperColor(CaliperColor caliperColor) { this.caliperColor = caliperColor; }
    public Set<SpecialEquipment> getEquipment() { return equipment; }
    public void setEquipment(Set<SpecialEquipment> equipment) { this.equipment = equipment; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
