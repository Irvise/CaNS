module mod_correc
  use mod_types
  implicit none
  private
  public correc
  contains
  subroutine correc(n,dli,dzci,dt,p,up,vp,wp,u,v,w)
    !
    ! corrects the velocity so that it is divergence free
    ! the boundary conditions are already incorporated here
    !
    implicit none
    integer , intent(in), dimension(3) :: n
    real(rp), intent(in), dimension(3) :: dli
    real(rp), intent(in), dimension(0:) :: dzci
    real(rp), intent(in) :: dt
    real(rp), intent(in) , dimension(0:,0:,0:) :: p,up,vp,wp
    real(rp), intent(out), dimension(0:,0:,0:) :: u,v,w
    real(rp) :: factori,factorj
    real(rp), dimension(0:n(3)+1) :: factork
    integer :: i,j,k,ip,jp,kp
    !
    !factor = rkcoeffab(rkiter)*dt
    !
    factori = dt*dli(1)
    factorj = dt*dli(2)
    factork = dt*dzci!dli(3)
    !$OMP PARALLEL DO DEFAULT(none) &
    !$OMP SHARED(n,factori,u,up,p) &
    !$OMP PRIVATE(i,j,k,ip)
    do k=0,n(3)+1
      do j=0,n(2)+1
        do i=0,n(1)
          ip = i+1
          u(i,j,k) = up(i,j,k) - factori*(   p(ip,j,k)-p(i,j,k))
        enddo
      enddo
    enddo
    !$OMP END PARALLEL DO
    !
    !$OMP PARALLEL DO DEFAULT(none) &
    !$OMP SHARED(n,factorj,v,vp,p) &
    !$OMP PRIVATE(i,j,k,jp)
    do k=0,n(3)+1
      do j=0,n(2)
        jp = j+1
        do i=0,n(1)+1
          v(i,j,k) = vp(i,j,k) - factorj*(   p(i,jp,k)-p(i,j,k))
        enddo
      enddo
    enddo
    !$OMP END PARALLEL DO
    !
    !$OMP END PARALLEL DO
    !$OMP PARALLEL DO DEFAULT(none) &
    !$OMP SHARED(n,factork,w,wp,p) &
    !$OMP PRIVATE(i,j,k,kp)
    do k=0,n(3)+1
      kp = k+1
      do j=0,n(2)
        do i=0,n(1)+1
          w(i,j,k) = wp(i,j,k) - factork(k)*(p(i,j,kp)-p(i,j,k))
        enddo
      enddo
    enddo
    !$OMP END PARALLEL DO
    !
    return
  end subroutine correc
end module mod_correc
