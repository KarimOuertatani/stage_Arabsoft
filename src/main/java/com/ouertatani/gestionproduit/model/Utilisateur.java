package com.ouertatani.gestionproduit.model;


import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "utilisateur")
public class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 50)
    private String nom;

    @Column(nullable = false, length = 50)
    private String prenom;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(nullable = false)
    private String motDePasse;

    @Column(length = 20)
    private String numeroTelephone;

    private LocalDate dateNaissance;

    @Enumerated(EnumType.STRING)
    @Column(name = "type_utilisateur", nullable = false)
    private TypeUtilisateur typeUtilisateur;

    // Constructeurs
    public Utilisateur() {}

    public Utilisateur(String nom, String prenom, String email, String motDePasse, String numeroTelephone, LocalDate dateNaissance, TypeUtilisateur typeUtilisateur) {
        this.nom = nom;
        this.prenom = prenom;
        this.email = email;
        this.motDePasse = motDePasse;
        this.numeroTelephone = numeroTelephone;
        this.dateNaissance = dateNaissance;
        this.typeUtilisateur = typeUtilisateur;
    }

    // Getters et setters

    public Integer getId() { return id; }

    public void setId(Integer id) { this.id = id; }

    public String getNom() { return nom; }

    public void setNom(String nom) { this.nom = nom; }

    public String getPrenom() { return prenom; }

    public void setPrenom(String prenom) { this.prenom = prenom; }

    public String getEmail() { return email; }

    public void setEmail(String email) { this.email = email; }

    public String getMotDePasse() { return motDePasse; }

    public void setMotDePasse(String motDePasse) { this.motDePasse = motDePasse; }

    public String getNumeroTelephone() { return numeroTelephone; }

    public void setNumeroTelephone(String numeroTelephone) { this.numeroTelephone = numeroTelephone; }

    public LocalDate getDateNaissance() { return dateNaissance; }

    public void setDateNaissance(LocalDate dateNaissance) { this.dateNaissance = dateNaissance; }

    public TypeUtilisateur getTypeUtilisateur() { return typeUtilisateur; }

    public void setTypeUtilisateur(TypeUtilisateur typeUtilisateur) { this.typeUtilisateur = typeUtilisateur; }

    // Enum interne pour le type d'utilisateur
    public enum TypeUtilisateur {
        ADMIN,
        CLIENT,
        FOURNISSEUR
    }
}