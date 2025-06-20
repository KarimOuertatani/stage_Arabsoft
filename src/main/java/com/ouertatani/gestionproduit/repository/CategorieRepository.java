package com.ouertatani.gestionproduit.repository;

import com.ouertatani.gestionproduit.model.Categorie;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CategorieRepository extends JpaRepository<Categorie, Integer> {}