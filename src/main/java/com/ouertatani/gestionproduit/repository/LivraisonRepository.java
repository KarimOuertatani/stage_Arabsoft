package com.ouertatani.gestionproduit.repository;

import com.ouertatani.gestionproduit.model.Livraison;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LivraisonRepository extends JpaRepository<Livraison, Long> {
}
