package com.ouertatani.gestionproduit.service;

import com.ouertatani.gestionproduit.model.CodeSecretClient;
import com.ouertatani.gestionproduit.repository.CodeSecretClientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class CodeSecretClientService {

    @Autowired
    private CodeSecretClientRepository repository;

    public CodeSecretClient save(CodeSecretClient code) {
        return repository.save(code);
    }

    public Optional<CodeSecretClient> findByUtilisateurIdAndCodeSecret(Integer utilisateurId, String codeSecret) {
        return repository.findByUtilisateurIdAndCodeSecret(utilisateurId, codeSecret);
    }

    public Optional<CodeSecretClient> getById(Long id) {
        return repository.findById(id);
    }

    public Optional<CodeSecretClient> findByUtilisateurId(Integer utilisateurId) {
        return repository.findByUtilisateurId(utilisateurId);
    }
}