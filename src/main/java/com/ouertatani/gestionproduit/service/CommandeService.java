package com.ouertatani.gestionproduit.service;

import com.ouertatani.gestionproduit.model.*;
import com.ouertatani.gestionproduit.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CommandeService {

    private final CommandeRepository commandeRepository;
    private final CommandeProduitRepository commandeProduitRepository;
    private final ProduitRepository produitRepository;
    private final LivraisonRepository livraisonRepository;

    public Commande ajouterProduitAuPanier(Long clientId, Long produitId, int quantite) {
        Produit produit = produitRepository.findById(Math.toIntExact(produitId))
                .orElseThrow(() -> new RuntimeException("Produit introuvable"));

        Commande commande = commandeRepository
                .findByClientIdAndStatut(clientId, Commande.StatutCommande.EN_ATTENTE)
                .orElseGet(() -> commandeRepository.save(
                        new Commande(null, null, clientId, Commande.StatutCommande.EN_ATTENTE, null, null)
                ));

        CommandeProduit cp = new CommandeProduit(null, commande, produit, quantite, produit.getPrix());
        commandeProduitRepository.save(cp);

        return commande;
    }

    public Commande getPanierClient(Long clientId) {
        return commandeRepository
                .findByClientIdAndStatut(clientId, Commande.StatutCommande.EN_ATTENTE)
                .orElse(null);
    }

    public Commande confirmerCommande(Long commandeId, String adresseLivraison) {
        Commande commande = commandeRepository.findById(commandeId)
                .orElseThrow(() -> new RuntimeException("Commande introuvable"));

        commande.setStatut(Commande.StatutCommande.CONFIRMEE);
        commandeRepository.save(commande);

        Livraison livraison = new Livraison(null, commande, adresseLivraison, Livraison.StatutLivraison.EN_ATTENTE);
        livraisonRepository.save(livraison);

        return commande;
    }
}
