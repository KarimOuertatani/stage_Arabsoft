package com.ouertatani.gestionproduit.service;

import com.ouertatani.gestionproduit.model.Categorie;
import com.ouertatani.gestionproduit.repository.CategorieRepository;
import javax.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategorieService {

    @Autowired
    private CategorieRepository categorieRepository;

    public List<Categorie> getAllCategories() {
        return categorieRepository.findAll();
    }

    public Categorie getCategorieById(Integer id) {
        return categorieRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Catégorie non trouvée : " + id));
    }

    public Categorie createCategorie(Categorie categorie) {
        return categorieRepository.save(categorie);
    }

    public Categorie updateCategorie(Integer id, Categorie categorieDetails) {
        Categorie categorie = getCategorieById(id);
        categorie.setNom(categorieDetails.getNom());
        return categorieRepository.save(categorie);
    }

    public void deleteCategorie(Integer id) {
        if (!categorieRepository.existsById(id)) {
            throw new EntityNotFoundException("Catégorie non trouvée : " + id);
        }
        categorieRepository.deleteById(id);
    }
}