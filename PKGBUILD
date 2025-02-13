# Maintainer: William Varmus <0@willvar.tw>
# Contributor: Leo <i@setuid0.dev>

_extname=uuid
pkgname=php-$_extname
pkgver=1.2.1
pkgrel=3
pkgdesc='UUID extension for PHP'
arch=('x86_64')
url='https://github.com/php/pecl-networking-uuid'
license=('LGPL')
depends=('php>=7.0')
source=("http://pecl.php.net/get/$_extname-$pkgver.tgz")
sha256sums=('2235c8584ca8911ce5512ebf791e5bb1d849c323640ad3e0be507b00156481c7')

prepare() {
  cd "${srcdir}/${_extname}-${pkgver}"
  phpize --clean
  phpize
  ./configure --prefix=/usr --with-uuid
  echo "extension=${_extname}.so" > "${_extname}.ini"
}

build() {
  cd "${srcdir}/${_extname}-${pkgver}"
  make
}

# check() {
#   cd "${srcdir}/${_extname}-${pkgver}"
#   TEST_PHP_ARGS="-q -n" make test
# }

package() {
  cd "${srcdir}/${_extname}-${pkgver}"
  make INSTALL_ROOT="${pkgdir}" install
  install -Dm644 "${_extname}.ini" "${pkgdir}/etc/php/conf.d/${_extname}.ini" \
  && install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
