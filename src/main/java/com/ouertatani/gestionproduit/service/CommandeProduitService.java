package com.ouertatani.gestionproduit.service;

import com.ouertatani.gestionproduit.model.Commande;
import com.ouertatani.gestionproduit.model.CommandeProduit;
import com.ouertatani.gestionproduit.repository.CommandeProduitRepository;
import com.ouertatani.gestionproduit.repository.CommandeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.math.BigDecimal;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CommandeProduitService {

    private final CommandeProduitRepository repository;
    private final CommandeProduitRepository commandeProduitRepository;
    private final CommandeRepository commandeRepository;

    public List<CommandeProduit> getAll() {
        return repository.findAll();
    }

    public List<CommandeProduit> getByCommandeId(Long commandeId) {
        return repository.findByCommandeId(commandeId);
    }

    public CommandeProduit getById(Long id) {
        return repository.findById(id).orElse(null);
    }

    public CommandeProduit save(CommandeProduit cp) {
        return repository.save(cp);
    }

    public void delete(Long id) {
        repository.deleteById(id);
    }

    public CommandeProduit augmenterQuantite(Long id) {
        CommandeProduit cp = commandeProduitRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Produit non trouvé"));
        cp.setQuantite(cp.getQuantite() + 1);
        commandeProduitRepository.save(cp);
        updateCommandeTotal(cp.getCommande());
        return cp;
    }

    public CommandeProduit diminuerQuantite(Long id) {
        CommandeProduit cp = commandeProduitRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Produit non trouvé"));
        if (cp.getQuantite() > 1) {
            cp.setQuantite(cp.getQuantite() - 1);
            commandeProduitRepository.save(cp);
            updateCommandeTotal(cp.getCommande());
        } else {
            supprimer(id);
        }
        return cp;
    }

    public void supprimer(Long id) {
        CommandeProduit cp = commandeProduitRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Produit non trouvé"));
        commandeProduitRepository.delete(cp);
        updateCommandeTotal(cp.getCommande());
    }

    private void updateCommandeTotal(Commande commande) {
        List<CommandeProduit> produits = commandeProduitRepository.findByCommandeId(commande.getId());
        BigDecimal total = produits.stream()
                .map(cp -> cp.getPrixUnitaire().multiply(BigDecimal.valueOf(cp.getQuantite())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        commande.setTotal(total.doubleValue());
        commandeRepository.save(commande);
    }

}
