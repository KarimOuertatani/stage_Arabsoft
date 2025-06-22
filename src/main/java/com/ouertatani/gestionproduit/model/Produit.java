package com.ouertatani.gestionproduit.model;

import javax.persistence.*;
import javax.validation.constraints.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.math.BigDecimal;

@Entity
@Table(name = "produit")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Produit {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank(message = "Nom requis")
    @Size(max = 100, message = "Nom trop long")
    private String nom;

    @Column(columnDefinition = "TEXT")
    private String description;

    @NotNull(message = "Prix requis")
    @DecimalMin(value = "0.0", message = "Prix doit être positif")
    @Column(precision = 10, scale = 2)
    private BigDecimal prix;

    @NotNull(message = "Quantité requise")
    @Min(value = 0, message = "Quantité doit être positive")
    private Integer quantite;

    @Lob
    @Column(columnDefinition = "LONGBLOB")
    private byte[] image;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categorie_id", nullable = false)
    @NotNull(message = "Catégorie requise")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Categorie categorie;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fournisseur_id", nullable = false)
    @NotNull(message = "Fournisseur requis")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Utilisateur fournisseur;
}