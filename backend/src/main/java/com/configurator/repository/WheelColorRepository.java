package com.configurator.repository;

import com.configurator.model.WheelColor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WheelColorRepository extends JpaRepository<WheelColor, Integer> {
}
