package com.configurator.repository;

import com.configurator.model.WheelDesign;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WheelDesignRepository extends JpaRepository<WheelDesign, Integer> {
}
