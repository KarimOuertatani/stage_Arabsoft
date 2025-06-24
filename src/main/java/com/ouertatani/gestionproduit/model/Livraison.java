package com.ouertatani.gestionproduit.model;

import lombok.*;
import javax.persistence.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Livraison {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "commande_id", nullable = false)
    private Commande commande;

    @Lob
    private String adresseLivraison;

    @Enumerated(EnumType.STRING)
    private StatutLivraison statut = StatutLivraison.EN_ATTENTE;

    public enum StatutLivraison {
        EN_ATTENTE, EN_COURS, LIVREE, ANNULEE
    }
}
