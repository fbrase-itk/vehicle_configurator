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
        options.put("engines", service.getAllEngines());
        options.put("paints", service.getAllPaints());
        options.put("wheels", service.getAllWheels());
        options.put("equipment", service.getAllEquipment());
        return options;
    }

    @GetMapping("/engines")
    public List<EngineOption> getEngines() {
        return service.getAllEngines();
    }

    @GetMapping("/paints")
    public List<PaintOption> getPaints() {
        return service.getAllPaints();
    }

    @GetMapping("/wheels")
    public List<WheelOption> getWheels() {
        return service.getAllWheels();
    }

    @GetMapping("/equipment")
    public List<SpecialEquipment> getEquipment() {
        return service.getAllEquipment();
    }

    @PostMapping("/configurations")
    public ResponseEntity<Map<String, Object>> saveConfiguration(@RequestBody ConfigurationRequest request) {
        Configuration config = service.saveConfiguration(
                request.engineId,
                request.paintId,
                request.wheelId,
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

    @PostMapping("/configurations/{id}/price")
    public ResponseEntity<Map<String, BigDecimal>> calculatePrice(
            @PathVariable String id,
            @RequestBody(required = false) PriceCalculationRequest request) {
        
        if (request != null) {
            Configuration tempConfig = new Configuration();
            if (request.engineId != null) {
                tempConfig.setEngine(service.getAllEngines().stream()
                        .filter(e -> e.getId().equals(request.engineId))
                        .findFirst().orElse(null));
            }
            if (request.paintId != null) {
                tempConfig.setPaint(service.getAllPaints().stream()
                        .filter(p -> p.getId().equals(request.paintId))
                        .findFirst().orElse(null));
            }
            if (request.wheelId != null) {
                tempConfig.setWheel(service.getAllWheels().stream()
                        .filter(w -> w.getId().equals(request.wheelId))
                        .findFirst().orElse(null));
            }
            
            Map<String, BigDecimal> response = new HashMap<>();
            response.put("totalPrice", service.calculateTotalPrice(tempConfig));
            return ResponseEntity.ok(response);
        }
        
        return service.getConfiguration(id)
                .map(config -> {
                    Map<String, BigDecimal> response = new HashMap<>();
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
        public Integer engineId;
        public Integer paintId;
        public Integer wheelId;
        public List<Integer> equipmentIds;
    }

    public static class PriceCalculationRequest {
        public Integer engineId;
        public Integer paintId;
        public Integer wheelId;
        public List<Integer> equipmentIds;
    }

    public static class OrderRequest {
        public String configurationId;
        public String customerName;
        public String customerEmail;
    }
}
