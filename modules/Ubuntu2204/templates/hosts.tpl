--- 
all:
  children:
    novos:
      hosts:
        ${vm_name}:
          ansible_host: ${ip_address}
          ansible_user: ${ansible_user}
          ansible_password: ${ansible_pass}
          ansible_become_pass: ${ansible_pass}
          host_key_checking: False
       
    padronizados:
      hosts:
        ${vm_name}:
          host_key_checking: False