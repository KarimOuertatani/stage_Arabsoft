package com.ouertatani.gestionproduit.service;

import com.ouertatani.gestionproduit.model.Produit;
import com.ouertatani.gestionproduit.repository.ProduitRepository;
import javax.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProduitService {

    @Autowired
    private ProduitRepository produitRepository;

    public List<Produit> getAllProduits() {
        return produitRepository.findAll();
    }

    public Produit getProduitById(Integer id) {
        return produitRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Produit non trouvé : " + id));
    }

    public Produit createProduit(Produit produit) {
        return produitRepository.save(produit);
    }

    public Produit updateProduit(Integer id, Produit produitDetails) {
        Produit produit = getProduitById(id);
        produit.setNom(produitDetails.getNom());
        produit.setDescription(produitDetails.getDescription());
        produit.setPrix(produitDetails.getPrix());
        produit.setQuantite(produitDetails.getQuantite());
        produit.setImage(produitDetails.getImage());
        produit.setCategorie(produitDetails.getCategorie());
        produit.setFournisseur(produitDetails.getFournisseur());
        return produitRepository.save(produit);
    }

    public void deleteProduit(Integer id) {
        if (!produitRepository.existsById(id)) {
            throw new EntityNotFoundException("Produit non trouvé : " + id);
        }
        produitRepository.deleteById(id);
    }
}