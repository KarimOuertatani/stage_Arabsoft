package com.ouertatani.gestionproduit.repository;

import com.ouertatani.gestionproduit.model.CodeSecretClient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CodeSecretClientRepository extends JpaRepository<CodeSecretClient, Long> {
    Optional<CodeSecretClient> findByUtilisateurIdAndCodeSecret(Integer utilisateurId, String codeSecret);
    Optional<CodeSecretClient> findByUtilisateurId(Integer utilisateurId);
}