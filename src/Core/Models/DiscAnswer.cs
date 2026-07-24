using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json;

namespace Desenvolvimento.Core.Models
{
    public class DiscAnswer
    {
        public Guid Id { get; set; } = Guid.NewGuid();
        public Guid UserId { get; set; }

        /// <summary>
        /// Respostas em formato JSON armazenadas no banco de dados
        /// </summary>
        public string? AnswersJson { get; set; }

        /// <summary>
        /// Dictionary para trabalhar com as respostas em memória
        /// </summary>
        [NotMapped]
        public Dictionary<string, int>? Answers
        {
            get
            {
                if (string.IsNullOrEmpty(AnswersJson))
                    return new Dictionary<string, int>();

                return JsonSerializer.Deserialize<Dictionary<string, int>>(AnswersJson) 
                    ?? new Dictionary<string, int>();
            }
            set
            {
                AnswersJson = value == null 
                    ? null 
                    : JsonSerializer.Serialize(value);
            }
        }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
