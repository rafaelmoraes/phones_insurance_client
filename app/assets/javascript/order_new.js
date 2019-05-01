(() => {
  const User = () => {
    const cpfRegex = /^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$/

    const id = document.querySelector('#order_user_id');
    const name = document.querySelector('#order_user_name');
    const email = document.querySelector('#order_user_email');
    const cpf = document.querySelector('#order_user_cpf');

    const isCPFValid = (rawCPF) => cpfRegex.test(rawCPF.trim())

    const clear = () => {
      id.value = '';
      name.value = '';
      email.value = '';
    }

    const fill = (user) => {
      id.value = user.id;
      name.value = user.name;
      cpf.value = user.cpf;
      email.value = user.email;
    }

    const findByCPF = (rawCPF) => {
      if (isCPFValid(rawCPF)) {
        fetch(`http://localhost:3000/users/search?cpf=${cpf.value}`)
          .then(response => response.json())
          .then(response => fill(response.user))
          .catch(clear)
      } else {
        clear();
      }
    }

    return { findByCPF: findByCPF };
  }

  document.querySelector("#order_user_cpf")
          .addEventListener('change', function() {
    User().findByCPF(this.value);
  });
})();
