package com.ouertatani.gestionproduit.model;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CommandeDTO {
    private Long id;
    private Long clientId;
    private LocalDateTime dateCommande;
    private String statut;
    private Double total;

    public CommandeDTO(Commande commande) {
        this.id = commande.getId();
        this.clientId = commande.getClientId();
        this.dateCommande = commande.getDateCommande();
        this.statut = commande.getStatut().name();
        this.total = commande.getTotal();
    }
}