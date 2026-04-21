package com.configurator.controller;

import com.configurator.model.*;
import com.configurator.service.ConfiguratorService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ConfiguratorController {
    private final ConfiguratorService service;

    public ConfiguratorController(ConfiguratorService service) {
        this.service = service;
    }

    @GetMapping("/options")
    public Map<String, Object> getAllOptions() {
        Map<String, Object> options = new HashMap<>();
        options.put("carModels", service.getAllCarModels());
        options.put("engines", service.getAllEngines());
        options.put("paints", service.getAllPaints());
        options.put("wheelDesigns", service.getAllWheelDesigns());
        options.put("wheelColors", service.getAllWheelColors());
        options.put("caliperColors", service.getAllCaliperColors());
        options.put("equipment", service.getAllEquipment());
        return options;
    }

    @GetMapping("/car-models")
    public List<CarModel> getCarModels() {
        return service.getAllCarModels();
    }

    @GetMapping("/car-models/{id}")
    public ResponseEntity<CarModel> getCarModel(@PathVariable Integer id) {
        return service.getCarModel(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/car-models/{id}/engines")
    public List<EngineOption> getEnginesByCarModel(@PathVariable Integer id) {
        return service.getEnginesByCarModel(id);
    }

    @GetMapping("/engines")
    public List<EngineOption> getEngines() {
        return service.getAllEngines();
    }

    @GetMapping("/paints")
    public List<PaintOption> getPaints() {
        return service.getAllPaints();
    }

    @GetMapping("/wheel-designs")
    public List<WheelDesign> getWheelDesigns() {
        return service.getAllWheelDesigns();
    }

    @GetMapping("/wheel-colors")
    public List<WheelColor> getWheelColors() {
        return service.getAllWheelColors();
    }

    @GetMapping("/caliper-colors")
    public List<CaliperColor> getCaliperColors() {
        return service.getAllCaliperColors();
    }

    @GetMapping("/equipment")
    public List<SpecialEquipment> getEquipment() {
        return service.getAllEquipment();
    }

    @PostMapping("/configurations")
    public ResponseEntity<Map<String, Object>> saveConfiguration(@RequestBody ConfigurationRequest request) {
        Configuration config = service.saveConfiguration(
                request.carModelId,
                request.engineId,
                request.paintId,
                request.wheelDesignId,
                request.wheelColorId,
                request.caliperColorId,
                request.equipmentIds
        );
        
        Map<String, Object> response = new HashMap<>();
        response.put("id", config.getId());
        response.put("configuration", config);
        response.put("totalPrice", service.calculateTotalPrice(config));
        
        return ResponseEntity.ok(response);
    }

    @GetMapping("/configurations/{id}")
    public ResponseEntity<Map<String, Object>> getConfiguration(@PathVariable String id) {
        return service.getConfiguration(id)
                .map(config -> {
                    Map<String, Object> response = new HashMap<>();
                    response.put("configuration", config);
                    response.put("totalPrice", service.calculateTotalPrice(config));
                    return ResponseEntity.ok(response);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/orders")
    public ResponseEntity<Order> createOrder(@RequestBody OrderRequest request) {
        Order order = service.createOrder(
                request.configurationId,
                request.customerName,
                request.customerEmail
        );
        return ResponseEntity.ok(order);
    }

    public static class ConfigurationRequest {
        public Integer carModelId;
        public Integer engineId;
        public Integer paintId;
        public Integer wheelDesignId;
        public Integer wheelColorId;
        public Integer caliperColorId;
        public List<Integer> equipmentIds;
    }

    public static class OrderRequest {
        public String configurationId;
        public String customerName;
        public String customerEmail;
    }
}
