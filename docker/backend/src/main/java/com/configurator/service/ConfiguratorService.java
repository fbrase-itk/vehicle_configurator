package com.configurator.service;

import com.configurator.model.*;
import com.configurator.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.*;

@Service
public class ConfiguratorService {
    private final EngineOptionRepository engineRepo;
    private final PaintOptionRepository paintRepo;
    private final WheelOptionRepository wheelRepo;
    private final SpecialEquipmentRepository equipmentRepo;
    private final ConfigurationRepository configRepo;
    private final OrderRepository orderRepo;

    public ConfiguratorService(
            EngineOptionRepository engineRepo,
            PaintOptionRepository paintRepo,
            WheelOptionRepository wheelRepo,
            SpecialEquipmentRepository equipmentRepo,
            ConfigurationRepository configRepo,
            OrderRepository orderRepo) {
        this.engineRepo = engineRepo;
        this.paintRepo = paintRepo;
        this.wheelRepo = wheelRepo;
        this.equipmentRepo = equipmentRepo;
        this.configRepo = configRepo;
        this.orderRepo = orderRepo;
    }

    public List<EngineOption> getAllEngines() {
        return engineRepo.findAll();
    }

    public List<PaintOption> getAllPaints() {
        return paintRepo.findAll();
    }

    public List<WheelOption> getAllWheels() {
        return wheelRepo.findAll();
    }

    public List<SpecialEquipment> getAllEquipment() {
        return equipmentRepo.findAll();
    }

    @Transactional
    public Configuration saveConfiguration(Integer engineId, Integer paintId, Integer wheelId, List<Integer> equipmentIds) {
        Configuration config = new Configuration();
        config.setId(UUID.randomUUID().toString());
        
        if (engineId != null) {
            config.setEngine(engineRepo.findById(engineId).orElse(null));
        }
        if (paintId != null) {
            config.setPaint(paintRepo.findById(paintId).orElse(null));
        }
        if (wheelId != null) {
            config.setWheel(wheelRepo.findById(wheelId).orElse(null));
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
        
        if (config.getEngine() != null) {
            total = total.add(config.getEngine().getPrice());
        }
        if (config.getPaint() != null) {
            total = total.add(config.getPaint().getPrice());
        }
        if (config.getWheel() != null) {
            total = total.add(config.getWheel().getPrice());
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
