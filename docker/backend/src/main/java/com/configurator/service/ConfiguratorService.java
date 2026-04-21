package com.configurator.service;

import com.configurator.model.*;
import com.configurator.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

@Service
public class ConfiguratorService {
    private final CarModelRepository carModelRepo;
    private final EngineOptionRepository engineRepo;
    private final PaintOptionRepository paintRepo;
    private final WheelDesignRepository wheelDesignRepo;
    private final WheelColorRepository wheelColorRepo;
    private final CaliperColorRepository caliperColorRepo;
    private final SpecialEquipmentRepository equipmentRepo;
    private final ConfigurationRepository configRepo;
    private final OrderRepository orderRepo;

    public ConfiguratorService(
            CarModelRepository carModelRepo,
            EngineOptionRepository engineRepo,
            PaintOptionRepository paintRepo,
            WheelDesignRepository wheelDesignRepo,
            WheelColorRepository wheelColorRepo,
            CaliperColorRepository caliperColorRepo,
            SpecialEquipmentRepository equipmentRepo,
            ConfigurationRepository configRepo,
            OrderRepository orderRepo) {
        this.carModelRepo = carModelRepo;
        this.engineRepo = engineRepo;
        this.paintRepo = paintRepo;
        this.wheelDesignRepo = wheelDesignRepo;
        this.wheelColorRepo = wheelColorRepo;
        this.caliperColorRepo = caliperColorRepo;
        this.equipmentRepo = equipmentRepo;
        this.configRepo = configRepo;
        this.orderRepo = orderRepo;
    }

    public List<CarModel> getAllCarModels() {
        return carModelRepo.findAll();
    }

    public Optional<CarModel> getCarModel(Integer id) {
        return carModelRepo.findById(id);
    }

    public List<EngineOption> getAllEngines() {
        return engineRepo.findAll();
    }

    public List<EngineOption> getEnginesByCarModel(Integer carModelId) {
        return engineRepo.findAll().stream()
                .filter(e -> e.getCarModel() != null && e.getCarModel().getId().equals(carModelId))
                .toList();
    }

    public List<PaintOption> getAllPaints() {
        return paintRepo.findAll();
    }

    public List<WheelDesign> getAllWheelDesigns() {
        return wheelDesignRepo.findAll();
    }

    public List<WheelColor> getAllWheelColors() {
        return wheelColorRepo.findAll();
    }

    public List<CaliperColor> getAllCaliperColors() {
        return caliperColorRepo.findAll();
    }

    public List<SpecialEquipment> getAllEquipment() {
        return equipmentRepo.findAll();
    }

    @Transactional
    public Configuration saveConfiguration(Integer carModelId, Integer engineId, Integer paintId, 
            Integer wheelDesignId, Integer wheelColorId, Integer caliperColorId, List<Integer> equipmentIds) {
        Configuration config = new Configuration();
        config.setId(UUID.randomUUID().toString());
        
        if (carModelId != null) {
            config.setCarModel(carModelRepo.findById(carModelId).orElse(null));
        }
        if (engineId != null) {
            config.setEngine(engineRepo.findById(engineId).orElse(null));
        }
        if (paintId != null) {
            config.setPaint(paintRepo.findById(paintId).orElse(null));
        }
        if (wheelDesignId != null) {
            config.setWheelDesign(wheelDesignRepo.findById(wheelDesignId).orElse(null));
        }
        if (wheelColorId != null) {
            config.setWheelColor(wheelColorRepo.findById(wheelColorId).orElse(null));
        }
        if (caliperColorId != null) {
            config.setCaliperColor(caliperColorRepo.findById(caliperColorId).orElse(null));
        }
        if (equipmentIds != null && !equipmentIds.isEmpty()) {
            Set<SpecialEquipment> equipment = new HashSet<>(equipmentRepo.findAllById(equipmentIds));
            config.setEquipment(equipment);
        }
        
        return configRepo.save(config);
    }

    public Optional<Configuration> getConfiguration(String id) {
        return configRepo.findById(id);
    }

    public BigDecimal calculateTotalPrice(Configuration config) {
        BigDecimal total = BigDecimal.ZERO;
        
        if (config.getCarModel() != null) {
            total = total.add(config.getCarModel().getBasePrice());
        }
        if (config.getEngine() != null) {
            total = total.add(config.getEngine().getPrice());
        }
        if (config.getPaint() != null) {
            total = total.add(config.getPaint().getPrice());
        }
        if (config.getWheelDesign() != null) {
            total = total.add(config.getWheelDesign().getPrice());
        }
        if (config.getWheelColor() != null) {
            total = total.add(config.getWheelColor().getPrice());
        }
        if (config.getCaliperColor() != null) {
            total = total.add(config.getCaliperColor().getPrice());
        }
        for (SpecialEquipment eq : config.getEquipment()) {
            total = total.add(eq.getPrice());
        }
        
        return total;
    }

    @Transactional
    public Order createOrder(String configurationId, String customerName, String customerEmail) {
        Configuration config = configRepo.findById(configurationId)
                .orElseThrow(() -> new RuntimeException("Configuration not found"));
        
        Order order = new Order();
        order.setConfiguration(config);
        order.setCustomerName(customerName);
        order.setCustomerEmail(customerEmail);
        order.setTotalPrice(calculateTotalPrice(config));
        
        return orderRepo.save(order);
    }
}
