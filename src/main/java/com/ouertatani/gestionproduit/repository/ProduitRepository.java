package com.ouertatani.gestionproduit.repository;

import com.ouertatani.gestionproduit.model.Produit;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProduitRepository extends JpaRepository<Produit, Integer> {

    // Tous les produits d'une catégorie
    List<Produit> findByCategorieId(Integer categorieId);

    // Tous les produits d'un fournisseur
    List<Produit> findByFournisseurId(Integer fournisseurId);

    // Rechercher par mot-clé (dans le nom)
    List<Produit> findByNomContainingIgnoreCase(String keyword);

    // Produits disponibles (quantité > 0)
    @Query("SELECT p FROM Produit p WHERE p.quantite > 0")
    List<Produit> findDisponibles();
}
