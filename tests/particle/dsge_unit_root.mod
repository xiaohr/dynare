// DGP
@#ifndef RISKY_CALIBRATION 
@#define RISKY_CALIBRATION = 0
@#endif
@#ifndef EXTREME_CALIBRATION
@#define EXTREME_CALIBRATION = 1
@#endif
@#ifndef BENCHMARK_CALIBRATION
@#define BENCHMARK_CALIBRATION = 0
@#endif

// ALGORITHM
@#ifndef LINEAR_KALMAN
@#define LINEAR_KALMAN = 0
@#endif
@#ifndef ALGO_SIR
@#define ALGO_SIR = 0
@#endif
@#ifndef ALGO_SISmoothR
@#define ALGO_SISmoothR = 0
@#endif
@#ifndef ALGO_APF
@#define ALGO_APF = 0
@#endif
@#ifndef ALGO_GPF
@#define ALGO_GPF = 0
@#endif
@#ifndef ALGO_GCF
@#define ALGO_GCF = 0
@#endif
@#ifndef ALGO_GUF
@#define ALGO_GUF = 1
@#endif
@#ifndef ALGO_GMPF
@#define ALGO_GMPF = 0
@#endif
@#ifndef ALGO_GMCF
@#define ALGO_GMCF = 0
@#endif
@#ifndef ALGO_ONLINE_1
@#define ALGO_ONLINE_1 = 0
@#endif
@#ifndef ALGO_ONLINE_2
@#define ALGO_ONLINE_2 = 0
@#endif
@#ifndef MCMC
@#define MCMC = 0
@#endif

var k A c l i y;
varexo e_a;

parameters alp bet tet tau delt rho ;
alp = 0.4;
bet = 0.99;
tet = 0.357 ;
tau =  50 ;
delt = 0.02;
rho = 1.0;

model;
c = ((1 - alp)*tet/(1-tet))*A*(1-l)*((k(-1)/l)^alp) ;
y = A*(k(-1)^alp)*(l^(1-alp)) ;
i = y-c ;
k = (1-delt)*k(-1) + i ;
log(A) = rho*log(A(-1)) + e_a ;
(((c^(tet))*((1-l)^(1-tet)))^(1-tau))/c - bet*((((c(+1)^(tet))*((1-l(+1))^(1-tet)))^(1-tau))/c(+1))*(1 -delt+alp*(A(1)*(k^alp)*(l(1)^(1-alp)))/k)=0 ;
end;

shocks;
var e_a; stderr 0.035;
end;

steady(nocheck);


stoch_simul(periods=5000, irf=0, noprint);

@#if EXTREME_CALIBRATION
    verbatim;
    y = y + randn(size(y))*.0175;
    l = l + randn(size(l))*.00312;
    i = i + randn(size(i))*.00465;
    end;
    ds = dseries([y, l, i, c, A], 1900Q1, {'y'; 'l'; 'i'; 'c'; 'A'});
@#endif 

@#if RISKY_CALIBRATION
    verbatim;
    y = y + randn(size(y))*.00158;
    l = l + randn(size(l))*.0011;
    i = i + randn(size(i))*.000866;
    end;
    ds = dseries([y, l, i, c, A], 1900Q1, {'y'; 'l'; 'i'; 'c'; 'A'});
@#endif

@#if BENCHMARK_CALIBRATION
    // TODO: This section is to be completed (measurement are missing)
    ds = dseries([y, l, i, c, A], 1900Q1, {'y'; 'l'; 'i'; 'c'; 'A'});
@#endif

estimated_params;
alp, uniform_pdf,,, 0.0001, 0.99;
bet, uniform_pdf,,, 0.0001, 0.99999;
tet, uniform_pdf,,, 0.0001, .999;
tau, uniform_pdf,,, 0.0001, 100;
delt, uniform_pdf,,, 0.0001, 0.05;
stderr e_a, uniform_pdf,,, 0.00001, 0.1;
stderr y, uniform_pdf,,, 0.00001, 0.1;
stderr l, uniform_pdf,,, 0.00001, 0.1;
stderr i, uniform_pdf,,, 0.00001, 0.1;
end;

@#if RISKY_CALIBRATION
  estimated_params_init;
  alp, 0.4;
  bet, 0.99;
  tet, 0.357;
  tau, 50;
  delt, 0.02;
  stderr e_a, .035;
  stderr y, .00158;
  stderr l, .0011;
  stderr i, .000866;
  end;
@#endif

@#if EXTREME_CALIBRATION
  estimated_params_init;
  alp, 0.4;
  bet, 0.99;
  tet, 0.357;
  tau, 50;
  delt, 0.02;
  stderr e_a, .035;
  stderr y, .0175;
  stderr l, .00312;
  stderr i, .00465;
  end;
@#endif

varobs y l i ;

options_.mode_check.neighbourhood_size = .01 ;
options_.mode_check.number_of_points = 250;

//options_.particle.initialization = 3;

@#if EXTREME_CALIBRATION
  data(series=ds, nobs=200, first_obs=1973Q1);
@#endif 

@#if RISKY_CALIBRATION
    data(series=ds, nobs=200, first_obs=1973Q1);
@#endif

@#if BENCHMARK_CALIBRATION
    data(series=ds, nobs = 200, first_obs=1973Q1);
@#endif


@#if LINEAR_KALMAN
%  estimation(nograph,order=1,mode_compute=8,mh_replic=0,mode_check);
@#endif

@#if ALGO_SIR
  estimation(order=2,nonlinear_filter_initialization=3,nograph,number_of_particles=1000,mh_replic=0,mode_compute=8,mode_check);
@#endif

@#if ALGO_SISmoothR
  estimation(order=2,nonlinear_filter_initialization=3,nograph,number_of_particles=1000,resampling_method=smooth,mode_compute=8,mh_replic=0);
  estimation(order=2,nonlinear_filter_initialization=3,nograph,number_of_particles=1000,resampling_method=smooth,mode_compute=8,mode_file=dsge_unit_root_mode,mh_replic=0);
  estimation(order=2,nonlinear_filter_initialization=3,nograph,number_of_particles=1000,resampling_method=smooth,mode_compute=4,mode_file=dsge_unit_root_mode,mh_replic=0,mode_check);
@#endif

@#if ALGO_APF
  estimation(order=2,nonlinear_filter_initialization=3,nograph,filter_algorithm=apf,number_of_particles=1000,mh_replic=0,mode_compute=8,mode_check);
@#endif

@#if ALGO_GPF
  estimation(order=2,nonlinear_filter_initialization=3,nograph,filter_algorithm=gf,distribution_approximation=montecarlo,number_of_particles=1000,mh_replic=0,mode_compute=8);
  estimation(order=2,nonlinear_filter_initialization=3,nograph,filter_algorithm=gf,distribution_approximation=montecarlo,number_of_particles=1000,mode_file=dsge_unit_root_mode,mh_replic=0,mode_compute=4,mode_check);
@#endif

@#if ALGO_GCF
  estimation(order=2,nonlinear_filter_initialization=3,nograph,filter_algorithm=gf,mh_replic=0,mode_compute=8);
  estimation(order=2,nonlinear_filter_initialization=3,nograph,filter_algorithm=gf,mh_replic=0,mode_compute=4,mode_file=dsge_unit_root_mode,mode_check);
@#endif

@#if ALGO_GUF
  estimation(order=2,nonlinear_filter_initialization=3,nograph,filter_algorithm=gf,proposal_approximation=unscented,distribution_approximation=unscented,mh_replic=0,mode_compute=4);
  estimation(order=2,nonlinear_filter_initialization=3,nograph,filter_algorithm=gf,proposal_approximation=unscented,distribution_approximation=unscented,mode_file=dsge_unit_root_mode,mh_replic=0,mode_compute=8,mode_check);
@#endif

@#if ALGO_GMPF
  estimation(nograph,order=2,nonlinear_filter_initialization=3,filter_algorithm=gmf,distribution_approximation=montecarlo,number_of_particles=1000,mh_replic=0,mode_compute=8);
  estimation(nograph,order=2,nonlinear_filter_initialization=3,filter_algorithm=gmf,distribution_approximation=montecarlo,number_of_particles=1000,mh_replic=0,mode_file=dsge_unit_root_mode,mode_compute=8);
  estimation(nograph,order=2,nonlinear_filter_initialization=3,filter_algorithm=gmf,distribution_approximation=montecarlo,number_of_particles=1000,mh_replic=0,mode_file=dsge_unit_root_mode,mode_compute=4,mode_check);
@#endif

@#if ALGO_GMCF
  estimation(nograph,order=2,nonlinear_filter_initialization=3,filter_algorithm=gmf,mh_replic=0,mode_compute=8);
  estimation(nograph,order=2,nonlinear_filter_initialization=3,filter_algorithm=gmf,mh_replic=0,mode_compute=4,mode_file=dsge_unit_root_mode,mode_check);
@#endif

@#if ALGO_ONLINE_2
  options_.particle.liu_west_delta = 0.9 ;
  estimation(order=2,number_of_particles=1000,mode_compute=11);
@#endif

@#if ALGO_ONLINE_1
  options_.particle.liu_west_delta = 0.9 ;
  estimation(order=1,number_of_particles=1000,mode_compute=11);
@#endif

@#if MCMC
  options_.mh_nblck = 10 ;
  options_.posterior_sampling_method = 'RWGMH';
  options_.rwgmh_scale_shock = (1e-5)*[10 10 1 1 10 10 10 1000 10 10] ;
  estimation(order=1,mh_replic=5000,mode_compute=0,mode_file=dsge_base2_mode);
@#endif