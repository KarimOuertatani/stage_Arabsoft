export interface CommandeProduit {
  id?: number;
  commandeId: number;
  produit: { id: number; nom: string };
  quantite: number;
  prixUnitaire: number;
}