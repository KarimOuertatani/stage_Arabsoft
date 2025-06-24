package com.ouertatani.gestionproduit.repository;

import com.ouertatani.gestionproduit.model.CommandeProduit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommandeProduitRepository extends JpaRepository<CommandeProduit, Long> {

    List<CommandeProduit> findByCommandeId(Long commandeId); // ✅ C'est ici qu'on la place
}
