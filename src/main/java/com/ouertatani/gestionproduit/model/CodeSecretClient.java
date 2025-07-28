package com.ouertatani.gestionproduit.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.*;

import javax.persistence.*;

@Entity
@Table(name = "code_secret_client")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CodeSecretClient {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "code_secret", nullable = false, length = 10)
    private String codeSecret;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "utilisateur_id", nullable = false)
    @JsonIgnore
    private Utilisateur utilisateur;
}
