package com.ouertatani.gestionproduit.repository;

import com.ouertatani.gestionproduit.model.Commande;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CommandeRepository extends JpaRepository<Commande, Long> {
    Optional<Commande> findByClientIdAndStatut(Long clientId, Commande.StatutCommande statut);
}
