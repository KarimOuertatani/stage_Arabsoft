package com.ouertatani.gestionproduit.service;

import com.ouertatani.gestionproduit.model.CommandeProduit;
import com.ouertatani.gestionproduit.repository.CommandeProduitRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CommandeProduitService {

    private final CommandeProduitRepository repository;

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
}
