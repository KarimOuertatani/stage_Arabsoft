package com.ouertatani.gestionproduit.service;

import com.ouertatani.gestionproduit.model.*;
import com.ouertatani.gestionproduit.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

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
                .orElseGet(() -> {
                    Commande nouvelleCommande = new Commande();
                    nouvelleCommande.setClientId(clientId);
                    nouvelleCommande.setDateCommande(LocalDateTime.now());
                    nouvelleCommande.setStatut(Commande.StatutCommande.EN_ATTENTE);
                    nouvelleCommande.setTotal(0.0);
                    return commandeRepository.save(nouvelleCommande);
                });

        CommandeProduit cp = new CommandeProduit(null, commande, produit, quantite, produit.getPrix());
        commandeProduitRepository.save(cp);

        // Calcul du total
        BigDecimal montantAjoute = produit.getPrix().multiply(BigDecimal.valueOf(quantite));
        commande.setTotal(commande.getTotal() + montantAjoute.doubleValue());

        commandeRepository.save(commande);

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
    public List<CommandeDTO> getCommandesByClientId(Long clientId) {
        List<Commande> commandes = commandeRepository.findByClientId(clientId);
        return commandes.stream()
                .map(CommandeDTO::new)
                .collect(Collectors.toList());
    }
    public List<CommandeDTO> getAllCommandes() {
        List<Commande> commandes = commandeRepository.findAll();
        return commandes.stream()
                .map(CommandeDTO::new)
                .collect(Collectors.toList());
    }
}
