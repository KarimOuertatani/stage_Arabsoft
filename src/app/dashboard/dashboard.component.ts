import { Component, OnInit, ViewChild, HostListener } from '@angular/core';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatGridListModule } from '@angular/material/grid-list';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatSidenav, MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatTableModule } from '@angular/material/table';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { ApiService } from '../services/api.service';
import { Commande } from '../models/commande.model';
import { Livraison } from '../models/livraison.model';
import { Produit } from '../models/produit.model';
import { Utilisateur } from '../models/utilisateur.model';
import { Categorie } from '../models/categorie.model';
import { CommonModule } from '@angular/common';
import { MtxAlertModule } from '@ng-matero/extensions/alert';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    MatGridListModule,
    MatCardModule,
    MatIconModule,
    MatButtonModule,
    MatSidenavModule,
    MatListModule,
    MatTableModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    NgChartsModule,
    RouterLink,
    RouterLinkActive,
    MtxAlertModule
  ]
})

export class DashboardComponent implements OnInit {
  @ViewChild('sidenav') sidenav!: MatSidenav;

  totalCommandes: number = 0;
  pendingDeliveries: number = 0;
  totalProduits: number = 0;
  totalUtilisateurs: number = 0;
  isShowAlert: boolean = true;
  isDarkTheme: boolean = false;
  isLoading: boolean = true;
  errorMessage: string | null = null;
  currentUser: Utilisateur | null = null;
  categoryStats: { name: string; count: number; percentage: number; id: number }[] = [];
  displayedColumns: string[] = ['category', 'count', 'percentage', 'actions'];
  isSidenavCollapsed: boolean = false;
  gridCols: number = 4;
  windowWidth: number = window.innerWidth;

  stats: { title: string; amount: number; icon: string; route: string; tooltip: string }[] = [
    { title: 'Total Orders', amount: 0, icon: 'shopping_cart', route: '/orders', tooltip: 'View all orders' },
    { title: 'Pending Deliveries', amount: 0, icon: 'local_shipping', route: '/deliveries', tooltip: 'View pending deliveries' },
    { title: 'Total Products', amount: 0, icon: 'inventory_2', route: '/products', tooltip: 'View all products' },
    { title: 'Total Users', amount: 0, icon: 'people', route: '/users', tooltip: 'View all users' }
  ];

  lineChartData: ChartData<'line'> = {
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    datasets: [
      {
        label: 'Orders Over Time',
        data: [50, 60, 70, 80, 90, 100],
        borderColor: '#2563eb',
        backgroundColor: 'rgba(37, 99, 235, 0.2)',
        fill: true,
        tension: 0.4
      }
    ]
  };

  lineChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: true, position: 'top', labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } } },
      tooltip: { enabled: true, backgroundColor: '#1f2a44', titleFont: { family: 'Inter, Roboto, sans-serif' }, bodyFont: { family: 'Inter, Roboto, sans-serif' } }
    },
    scales: {
      y: { beginAtZero: true, title: { display: true, text: 'Number of Orders', font: { family: 'Inter, Roboto, sans-serif', size: 14 } } },
      x: { title: { display: true, text: 'Month', font: { family: 'Inter, Roboto, sans-serif', size: 14 } } }
    }
  };

  pieChartData: ChartData<'pie'> = {
    labels: [],
    datasets: [
      {
        data: [],
        backgroundColor: ['#2563eb', '#14b8a6', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#6b7280'],
        borderColor: '#ffffff',
        borderWidth: 2
      }
    ]
  };

  pieChartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: true, position: 'right', labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } } },
      tooltip: { enabled: true, backgroundColor: '#1f2a44', titleFont: { family: 'Inter, Roboto, sans-serif' }, bodyFont: { family: 'Inter, Roboto, sans-serif' } }
    }
  };

  constructor(private apiService: ApiService, private router: Router) {}

  @HostListener('window:resize', ['$event'])
  onResize(event: Event): void {
    this.windowWidth = window.innerWidth;
    this.gridCols = this.windowWidth <= 599 ? 1 : 4;
    this.isSidenavCollapsed = this.windowWidth <= 599;
  }

  ngOnInit(): void {
    this.isShowAlert = localStorage.getItem('showAlert') !== 'false';
    this.isDarkTheme = localStorage.getItem('theme') === 'dark';
    this.gridCols = this.windowWidth <= 599 ? 1 : 4;
    this.isSidenavCollapsed = this.windowWidth <= 599;

    const token = localStorage.getItem('jwt_token');
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    this.apiService.getCurrentUser().subscribe({
      next: (user) => {
        this.currentUser = user;
        this.loadData();
      },
      error: (err) => {
        console.error('Error fetching current user:', err);
        this.router.navigate(['/login']);
      }
    });
  }

  private loadData(): void {
    this.isLoading = true;
    this.errorMessage = null;

    let completedRequests = 0;
    const totalRequests = this.apiService.getCategories() ? 5 : 4;

    const checkLoading = () => {
      completedRequests++;
      if (completedRequests === totalRequests) {
        this.isLoading = false;
      }
    };

    this.apiService.getCommandes().subscribe({
      next: (commandes: Commande[]) => {
        this.totalCommandes = commandes.length;
        this.stats[0].amount = this.totalCommandes;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des commandes:', err);
        this.errorMessage = 'Failed to load orders. Please try again.';
      },
      complete: checkLoading
    });

    this.apiService.getLivraisons().subscribe({
      next: (livraisons: Livraison[]) => {
        this.pendingDeliveries = livraisons.filter(l => l.statut === 'EN_ATTENTE').length;
        this.stats[1].amount = this.pendingDeliveries;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des livraisons:', err);
        this.errorMessage = 'Failed to load deliveries. Please try again.';
      },
      complete: checkLoading
    });

    this.apiService.getProduits().subscribe({
      next: (produits: Produit[]) => {
        this.totalProduits = produits.length;
        this.stats[2].amount = this.totalProduits;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des produits:', err);
        this.errorMessage = 'Failed to load products. Please try again.';
      },
      complete: checkLoading
    });

    this.apiService.getUtilisateurs().subscribe({
      next: (utilisateurs: Utilisateur[]) => {
        this.totalUtilisateurs = utilisateurs.length;
        this.stats[3].amount = this.totalUtilisateurs;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des utilisateurs:', err);
        this.errorMessage = 'Failed to load users. Please try again.';
      },
      complete: checkLoading
    });

    if (this.apiService.getCategories) {
      this.apiService.getCategories().subscribe({
        next: (categories: Categorie[]) => {
          this.apiService.getProduits().subscribe({
            next: (produits: Produit[]) => {
              const totalProducts = produits.length || 1;
              this.categoryStats = categories.map(category => ({
                name: category.nom,
                count: produits.filter(p => p.categorie?.id === category.id).length,
                percentage: Number(((produits.filter(p => p.categorie?.id === category.id).length / totalProducts) * 100).toFixed(1)),
                id: category.id
              }));
              this.pieChartData = {
                labels: this.categoryStats.map(c => c.name),
                datasets: [
                  {
                    data: this.categoryStats.map(c => c.count),
                    backgroundColor: ['#2563eb', '#14b8a6', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#6b7280'],
                    borderColor: '#ffffff',
                    borderWidth: 2
                  }
                ]
              };
            },
            error: (err) => {
              console.error('Erreur lors de la récupération des produits pour catégories:', err);
              this.errorMessage = 'Failed to load category data. Please try again.';
            },
            complete: checkLoading
          });
        },
        error: (err) => {
          console.error('Erreur lors de la récupération des catégories:', err);
          this.errorMessage = 'Failed to load categories. Please try again.';
        },
        complete: checkLoading
      });
    } else {
      checkLoading();
    }
  }

  onAlertDismiss(): void {
    this.isShowAlert = false;
    localStorage.setItem('showAlert', 'false');
  }

  toggleTheme(): void {
    this.isDarkTheme = !this.isDarkTheme;
    localStorage.setItem('theme', this.isDarkTheme ? 'dark' : 'light');
    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  onStatClick(stat: { route: string }): void {
    this.router.navigate([stat.route]);
  }

  viewCategory(stat: { id: number }): void {
    this.router.navigate(['/categories', stat.id]);
  }

  toggleSidenav(): void {
    this.isSidenavCollapsed = !this.isSidenavCollapsed;
    this.sidenav.toggle();
  }

  logout(): void {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('theme');
    localStorage.removeItem('showAlert');
    this.router.navigate(['/login']);
  }

  retry(): void {
    this.loadData();
  }
}