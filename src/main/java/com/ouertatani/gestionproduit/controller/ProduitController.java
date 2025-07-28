package com.ouertatani.gestionproduit.controller;

import com.ouertatani.gestionproduit.model.Categorie;
import com.ouertatani.gestionproduit.model.Produit;
import com.ouertatani.gestionproduit.model.Utilisateur;
import com.ouertatani.gestionproduit.service.ProduitService;
import javax.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import javax.validation.Valid;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@RestController
@RequestMapping("/api/produits")
public class ProduitController {

    @Autowired
    private ProduitService produitService;

    @GetMapping
    public List<Produit> getAllProduits() {
        return produitService.getAllProduits();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Produit> getProduitById(@PathVariable Integer id) {
        try {
            Produit produit = produitService.getProduitById(id);
            return ResponseEntity.ok(produit);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @PostMapping
    public ResponseEntity<Produit> createProduit(@Valid @RequestBody Produit produit) {
        Produit createdProduit = produitService.createProduit(produit);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdProduit);
    }

    @PostMapping("/upload")
    public ResponseEntity<Produit> createProduitWithImage(
            @RequestParam("nom") String nom,
            @RequestParam(value = "description", required = false) String description,
            @RequestParam("prix") BigDecimal prix,
            @RequestParam("quantite") Integer quantite,
            @RequestParam(value = "image", required = false) MultipartFile imageFile,
            @RequestParam("categorieId") Integer categorieId,
            @RequestParam("fournisseurId") Integer fournisseurId) {
        try {
            Produit produit = new Produit();
            produit.setNom(nom);
            produit.setDescription(description);
            produit.setPrix(prix);
            produit.setQuantite(quantite);
            if (imageFile != null && !imageFile.isEmpty()) {
                produit.setImage(imageFile.getBytes());
            }
            produit.setCategorie(new Categorie());
            produit.getCategorie().setId(categorieId);
            produit.setFournisseur(new Utilisateur());
            produit.getFournisseur().setId(fournisseurId);

            Produit createdProduit = produitService.createProduit(produit);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdProduit);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<Produit> updateProduit(@PathVariable Integer id, @Valid @RequestBody Produit produit) {
        try {
            Produit updatedProduit = produitService.updateProduit(id, produit);
            return ResponseEntity.ok(updatedProduit);
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @PutMapping("/{id}/upload")
    public ResponseEntity<Produit> updateProduitWithImage(
            @PathVariable Integer id,
            @RequestParam("nom") String nom,
            @RequestParam(value = "description", required = false) String description,
            @RequestParam("prix") BigDecimal prix,
            @RequestParam("quantite") Integer quantite,
            @RequestParam(value = "image", required = false) MultipartFile imageFile,
            @RequestParam("categorieId") Integer categorieId,
            @RequestParam("fournisseurId") Integer fournisseurId) {
        try {
            Produit produit = produitService.getProduitById(id);
            produit.setNom(nom);
            produit.setDescription(description);
            produit.setPrix(prix);
            produit.setQuantite(quantite);
            if (imageFile != null && !imageFile.isEmpty()) {
                produit.setImage(imageFile.getBytes());
            }
            produit.setCategorie(new Categorie());
            produit.getCategorie().setId(categorieId);
            produit.setFournisseur(new Utilisateur());
            produit.getFournisseur().setId(fournisseurId);

            Produit updatedProduit = produitService.updateProduit(id, produit);
            return ResponseEntity.ok(updatedProduit);
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduit(@PathVariable Integer id) {
        try {
            produitService.deleteProduit(id);
            return ResponseEntity.noContent().build();
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }
    @GetMapping("/{id}/image")
    public ResponseEntity<byte[]> getProduitImage(@PathVariable Integer id) {
        try {
            Produit produit = produitService.getProduitById(id);
            if (produit.getImage() != null) {
                return ResponseEntity.ok()
                        .header(HttpHeaders.CONTENT_TYPE, "image/jpeg")
                        .body(produit.getImage());
            }
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        } catch (EntityNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }
    }
}