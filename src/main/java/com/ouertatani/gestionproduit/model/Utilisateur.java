package com.ouertatani.gestionproduit.model;

import javax.persistence.*;
import javax.validation.constraints.*;
import lombok.Data;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateSerializer;

import java.time.LocalDate;

@Entity
@Table(name = "utilisateur")
@Data
public class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @NotBlank(message = "Le nom est obligatoire")
    @Size(max = 50, message = "Le nom ne doit pas dépasser 50 caractères")
    @Column(nullable = false, length = 50)
    private String nom;

    @NotBlank(message = "Le prénom est obligatoire")
    @Size(max = 50, message = "Le prénom ne doit pas dépasser 50 caractères")
    @Column(nullable = false, length = 50)
    private String prenom;

    @NotBlank(message = "L'email est obligatoire")
    @Email(message = "L'email doit être valide")
    @Size(max = 100, message = "L'email ne doit pas dépasser 100 caractères")
    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @NotBlank(message = "Le mot de passe est obligatoire")
    @Column(name = "mot_de_passe", nullable = false)
    private String motDePasse;

    @Size(max = 20, message = "Le numéro de téléphone ne doit pas dépasser 20 caractères")
    @Column(name = "numero_telephone", length = 20)
    private String numeroTelephone;

    @Past(message = "La date de naissance doit être dans le passé")
    @Column(name = "date_naissance")
    @JsonSerialize(using = LocalDateSerializer.class)
    @JsonDeserialize(using = LocalDateDeserializer.class)
    private LocalDate dateNaissance;

    @NotNull(message = "Le type d'utilisateur est obligatoire")
    @Enumerated(EnumType.STRING)
    @Column(name = "type_utilisateur", nullable = false)
    private TypeUtilisateur typeUtilisateur;

    public enum TypeUtilisateur {
        ADMIN, CLIENT, FOURNISSEUR
    }
}