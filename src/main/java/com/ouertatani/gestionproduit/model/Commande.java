package com.ouertatani.gestionproduit.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import lombok.*;
import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Commande {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDateTime dateCommande = LocalDateTime.now();

    @Column(nullable = false)
    private Long clientId;

    @Enumerated(EnumType.STRING)
    private StatutCommande statut = StatutCommande.EN_ATTENTE;

    @OneToMany(mappedBy = "commande", cascade = CascadeType.ALL)
    @JsonManagedReference  // ← empêche la boucle avec CommandeProduit
    private List<CommandeProduit> produits;

    @OneToOne(mappedBy = "commande", cascade = CascadeType.ALL)
    @JsonManagedReference  // ← empêche la boucle avec Livraison
    private Livraison livraison;

    public enum StatutCommande {
        EN_ATTENTE, CONFIRMEE
    }
}
