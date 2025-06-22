package com.ouertatani.gestionproduit.model;

import javax.persistence.*;
import javax.validation.constraints.*;
import lombok.*;

@Entity
@Table(name = "categorie")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Categorie {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank(message = "Nom requis")
    @Size(max = 100, message = "Nom trop long")
    @Column(unique = true)
    private String nom;
}