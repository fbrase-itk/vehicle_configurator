package com.configurator.repository;

import com.configurator.model.CaliperColor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CaliperColorRepository extends JpaRepository<CaliperColor, Integer> {
}
