package com.ouertatani.gestionproduit.model;

import lombok.Data;

@Data
public class LivraisonDTO {
    private Long id;
    private Long commandeId;
    private String adresseLivraison;
    private String statut;

    public LivraisonDTO(Livraison livraison) {
        this.id = livraison.getId();
        this.commandeId = livraison.getCommande().getId();
        this.adresseLivraison = livraison.getAdresseLivraison();
        this.statut = livraison.getStatut().name();
    }
}