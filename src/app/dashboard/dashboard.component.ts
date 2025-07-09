import { Component, OnInit } from '@angular/core';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatGridListModule } from '@angular/material/grid-list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { ApiService } from '../services/api.service';
import { Commande } from '../models/commande.model';
import { Livraison } from '../models/livraison.model';
import { Produit } from '../models/produit.model';
import { Utilisateur } from '../models/utilisateur.model';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss'],
  standalone: true,
  imports: [
    MatGridListModule,
    MatCardModule,
    MatIconModule,
    MatButtonModule,
    MatSidenavModule,
    MatListModule,
    NgChartsModule,
    RouterLink,
    RouterLinkActive
  ]
})
export class DashboardComponent implements OnInit {
  totalCommandes: number = 0;
  pendingDeliveries: number = 0;
  totalProduits: number = 0;
  totalUtilisateurs: number = 0;
  isShowAlert: boolean = true;

  stats = [
    { title: 'Total Orders', amount: 0 },
    { title: 'Pending Deliveries', amount: 0 },
    { title: 'Total Products', amount: 0 },
    { title: 'Total Users', amount: 0 }
  ];

  lineChartData: ChartData<'line'> = {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [
      {
        label: 'Orders Over Time',
        data: [50, 60, 70, 80, 90, 100],
        borderColor: '#1976d2',
        backgroundColor: 'rgba(25, 118, 210, 0.1)',
        fill: true,
        tension: 0.4
      }
    ]
  };

  lineChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: true,
        position: 'top'
      }
    },
    scales: {
      y: {
        beginAtZero: true,
        title: {
          display: true,
          text: 'Number of Orders'
        }
      },
      x: {
        title: {
          display: true,
          text: 'Month'
        }
      }
    }
  };

  constructor(private apiService: ApiService, private router: Router) {}

  ngOnInit() {
    const token = localStorage.getItem('jwt_token');
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    this.apiService.getCurrentUser().subscribe({
      next: (user) => {
        if (user.typeUtilisateur === 'ADMIN') {
          this.router.navigate(['/login']);
          return;
        }
        this.loadData();
      },
      error: (err) => {
        this.router.navigate(['/login']);
      }
    });
  }

  private loadData() {
    this.apiService.getCommandes().subscribe({
      next: (commandes: Commande[]) => {
        this.totalCommandes = commandes.length;
        this.stats[0].amount = this.totalCommandes;
      },
      error: (err) => console.error('Erreur lors de la récupération des commandes:', err)
    });

    this.apiService.getLivraisons().subscribe({
      next: (livraisons: Livraison[]) => {
        this.pendingDeliveries = livraisons.filter(l => l.statut === 'EN_ATTENTE').length;
        this.stats[1].amount = this.pendingDeliveries;
      },
      error: (err) => console.error('Erreur lors de la récupération des livraisons:', err)
    });

    this.apiService.getProduits().subscribe({
      next: (produits: Produit[]) => {
        this.totalProduits = produits.length;
        this.stats[2].amount = this.totalProduits;
      },
      error: (err) => console.error('Erreur lors de la récupération des produits:', err)
    });

    this.apiService.getUtilisateurs().subscribe({
      next: (utilisateurs: Utilisateur[]) => {
        this.totalUtilisateurs = utilisateurs.length;
        this.stats[3].amount = this.totalUtilisateurs;
      },
      error: (err) => console.error('Erreur lors de la récupération des utilisateurs:', err)
    });
  }

  onAlertDismiss() {
    this.isShowAlert = false;
  }
}